// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Default URL for triggering event grid function in the local environment.
// http://localhost:7071/runtime/webhooks/EventGrid?functionName={functionname}
using Azure.Messaging.EventGrid;
using Azure.Messaging.EventGrid.SystemEvents;
using IFS.AD.FunctionApps.IotMessageAggregator.Models;
using IFS.AD.FunctionApps.Shared.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace IFS.AD.FunctionApps.IotMessageAggregator
{
    public class Aggregator
    {
        readonly AggregatorOptions _options;
        readonly IDatabase _redis;
        readonly EventGridPublisherClient _eventGridPublisherClient;

        public Aggregator(IOptions<AggregatorOptions> options, IConnectionMultiplexer muxer, EventGridPublisherClient eventGridPublisherClient)
        {
            _options = options.Value;
            _redis = muxer.GetDatabase();
            _eventGridPublisherClient = eventGridPublisherClient;
        }

        [FunctionName("Aggregator")]
        public async Task RunAsync([EventGridTrigger] EventGridEvent eventGridEvent, ILogger log)
        {
            var eventGridEventData = eventGridEvent.Data.ToString();
            log.LogDebug("EventGridEvent.Data: {EventGridEvent.Data}", eventGridEventData);

            // Deserialize the IoT Hub device message and handle the body
            var deviceEventData = JsonSerializer.Deserialize<IotHubDeviceTelemetryEventData>(eventGridEventData);
            var deviceEventDataBody = GetDeviceEventDataJson(deviceEventData.Body.ToString());
            log.LogDebug("IotHubDeviceTelemetryEventData.Body: {IotHubDeviceTelemetryEventData.Body}", deviceEventDataBody);

            // Deserialize the device message to our special message type
            var deviceMessage = JsonSerializer.Deserialize<ThermostatDeviceMessage>(deviceEventDataBody);

            if (deviceMessage is not null &&
                DateTimeOffset.TryParse(deviceEventData.SystemProperties["iothub-enqueuedtime"], out var timestamp))
            {
                // Set the device message timestamp and retrieve the device ID
                deviceMessage.Timestamp = timestamp;
                var deviceId = deviceEventData.SystemProperties["iothub-connection-device-id"];

                if (!string.IsNullOrWhiteSpace(deviceId))
                {
                    // Serialize only the part of the original device message that we're interested in
                    var deviceMessageJson = JsonSerializer.Serialize(deviceMessage);

                    // Store this device message using a lexicographic sorted set time series
                    // https://redis.com/redis-best-practices/time-series/lexicographic-sorted-set-time-series/
                    await _redis.SortedSetAddAsync(
                        key: deviceId,
                        member: $"{deviceMessage.Timestamp.ToUnixTimeMilliseconds()}:{deviceMessageJson}",
                        score: 0
                        ).ConfigureAwait(false);

                    // Check how many device messages have been stored thus far
                    var sortedSetLength = await _redis.SortedSetLengthAsync(deviceId).ConfigureAwait(false);
                    log.LogInformation("{DeviceId} has {SortedSetLength} cached items", deviceId, sortedSetLength);

                    // The anomaly detector MVAD service requires a minimum number of records in the sliding window
                    // https://learn.microsoft.com/en-us/azure/cognitive-services/anomaly-detector/concepts/best-practices-multivariate#optional-parameters-for-training-api
                    if (sortedSetLength >= _options.AnomalyDetectorSlidingWindow)
                    {
                        // Retrieve the records from Redis while popping the first element
                        var firstEntry = await _redis.SortedSetPopAsync(deviceId).ConfigureAwait(false);
                        var remainingEntries = await _redis.SortedSetRangeByRankAsync(
                            key: deviceId,
                            start: 0,
                            stop: _options.AnomalyDetectorSlidingWindow - 2
                            ).ConfigureAwait(false);

                        // Create and log the aggregate message
                        var redisValues = new List<RedisValue> { firstEntry.Value.Element };
                        redisValues.AddRange(remainingEntries);

                        var aggregateMessage = new AggregateMessage
                        {
                            DeviceId = deviceId,
                            DeviceMessages = redisValues.Select(redisValue =>
                            {
                                var redisValueString = redisValue.ToString();
                                var deviceMessageJson = redisValueString.Substring(redisValueString.IndexOf(":") + 1);

                                return JsonSerializer.Deserialize<ThermostatDeviceMessage>(deviceMessageJson);
                            })
                        };
                        log.LogDebug("AggregateMessage: {AggregateMessage}", JsonSerializer.Serialize(aggregateMessage));

                        // Send the aggregate message to our separate anomaly detector invoker process
                        var eventGridEventOut = new EventGridEvent(
                            subject: nameof(AggregateMessage),
                            eventType: typeof(AggregateMessage).ToString(),
                            dataVersion: "1.0.0",
                            data: aggregateMessage,
                            dataSerializationType: typeof(AggregateMessage));

                        await _eventGridPublisherClient.SendEventAsync(eventGridEventOut).ConfigureAwait(false);
                    }
                }
            }
        }

        /// <summary>
        /// Some times the messages will come base64 encoded, but other times not.
        /// It depends on how or if the content-type property of the message was set.
        /// https://learn.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-messages-construct
        /// </summary>
        string GetDeviceEventDataJson(string deviceEventDataBody)
        {
            var bytes = new Span<byte>(new byte[deviceEventDataBody.Length]);

            // Decode the body if it's base64 encoded
            return Convert.TryFromBase64String(deviceEventDataBody, bytes, out int byteCount)
                ? Encoding.UTF8.GetString(bytes.ToArray(), 0, byteCount)
                : deviceEventDataBody;
        }
    }
}