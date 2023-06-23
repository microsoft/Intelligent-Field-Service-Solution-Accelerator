// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using AD.FunctionApps.AnomalyDetectorInvoker;
using AD.FunctionApps.AnomalyDetectorInvoker.Models;
using Azure;
using Azure.AI.AnomalyDetector;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using System;

[assembly: FunctionsStartup(typeof(Startup))]

namespace AD.FunctionApps.AnomalyDetectorInvoker
{
    class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            builder.ConfigurationBuilder.AddAzureAppConfiguration(options =>
            {
                var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings:AppConfiguration");
                options.Connect(connectionString);
            });
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddOptions<InvokerOptions>()
                .Configure<IConfiguration>((options, configuration) =>
                {
                    configuration.GetSection(nameof(InvokerOptions)).Bind(options);
                });

            builder.Services.AddSingleton(serviceProvider =>
            {
                var options = serviceProvider.GetRequiredService<IOptions<InvokerOptions>>().Value;
                var credential = new AzureKeyCredential(options.AnomalyDetectorKey);

                return new AnomalyDetectorClient(options.AnomalyDetectorUri, credential);
            });

            builder.Services.AddSingleton(serviceProvider =>
            {
                var options = serviceProvider.GetRequiredService<IOptions<InvokerOptions>>().Value;

                var serviceBusClient = new ServiceBusClient(options.ServiceBusConnectionString);
                return serviceBusClient.CreateSender(options.ServiceBusQueueName);
            });
        }
    }
}
