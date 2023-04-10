// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Default URL for triggering event grid function in the local environment.
// http://localhost:7071/runtime/webhooks/EventGrid?functionName={functionname}
using Azure.AI.AnomalyDetector;
using Azure.Messaging.EventGrid;
using Azure.Messaging.ServiceBus;
using IFS.AD.FunctionApps.AnomalyDetectorInvoker.Models;
using IFS.AD.FunctionApps.Shared.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace IFS.AD.FunctionApps.AnomalyDetectorInvoker
{
    public class Invoker
    {
        readonly InvokerOptions _options;
        readonly AnomalyDetectorClient _anomalyDetectorClient;
        readonly ServiceBusSender _serviceBusSender;

        public Invoker(IOptions<InvokerOptions> options, AnomalyDetectorClient anomalyDetectorClient, ServiceBusSender serviceBusSender)
        {
            _options = options.Value;
            _anomalyDetectorClient = anomalyDetectorClient;
            _serviceBusSender = serviceBusSender;
        }

        [FunctionName("Invoker")]
        public async Task Run([EventGridTrigger] EventGridEvent eventGridEvent, ILogger log)
        {
            var eventGridEventData = eventGridEvent.Data.ToString();
            log.LogDebug("EventGridEvent.Data: {EventGridEvent.Data}", eventGridEventData);

            // Deserialize the aggregate message and create the variables
            var aggregateMessage = JsonSerializer.Deserialize<AggregateMessage>(eventGridEventData);
            var timestamps = aggregateMessage.DeviceMessages.Select(deviceMessage => deviceMessage.Timestamp.ToString("O"));

            var variables = new List<VariableValues>
            {
                new VariableValues(
                    variable: nameof(ThermostatDeviceMessage.Temperature).ToLowerInvariant(),
                    timestamps,
                    values: aggregateMessage.DeviceMessages.Select(deviceMessage =>
                    {
                        var temperature = (deviceMessage as ThermostatDeviceMessage).Temperature;
                        return (float)temperature;
                    })),
                new VariableValues(
                    variable: nameof(ThermostatDeviceMessage.Humidity).ToLowerInvariant(),
                    timestamps,
                    values: aggregateMessage.DeviceMessages.Select(deviceMessage =>
                    {
                        var humidity = (deviceMessage as ThermostatDeviceMessage).Humidity;
                        return (float)humidity;
                    }))
            };

            // Build and send the MVAD options
            var modelId = _options.AnomalyDetectorModelId.ToString();
            var options = new MultivariateLastDetectionOptions(variables, variables.Count);
            var response = await _anomalyDetectorClient.DetectMultivariateLastAnomalyAsync(modelId, options)
                .ConfigureAwait(false);

            // If the response is OK and the result is anomalous
            if (response.GetRawResponse().Status == 200)
            {
                var lastDeviceMessage = aggregateMessage.DeviceMessages.Last();
                var result = response.Value.Results.FirstOrDefault();

                if (result is not null && result.Value.IsAnomaly)
                {
                    var anomalyDetectionData = new ThermostatAnomalyDetectionData(result.Value.Severity, "Anomaly Detection", "AlertMultiAnom")
                    {
                        DeviceId = aggregateMessage.DeviceId,
                        EventToken = response.GetRawResponse().ClientRequestId,
                        Time = result.Timestamp.ToString("O"),

                        Score = result.Value.Score,
                        Severity = result.Value.Severity,

                        Humidity = lastDeviceMessage.Humidity,
                        Temperature = lastDeviceMessage.Temperature
                    };

                    // Build and send the message to the Connected Field Service
                    var alertDataJson = JsonSerializer.Serialize(anomalyDetectionData);
                    var serviceBusMessage = new ServiceBusMessage(alertDataJson);
                    await _serviceBusSender.SendMessageAsync(serviceBusMessage).ConfigureAwait(false);
                }
            }
        }
    }
}
