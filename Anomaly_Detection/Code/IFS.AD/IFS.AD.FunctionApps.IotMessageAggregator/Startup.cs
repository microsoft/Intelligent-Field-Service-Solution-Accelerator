// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Azure;
using Azure.Messaging.EventGrid;
using IFS.AD.FunctionApps.IotMessageAggregator;
using IFS.AD.FunctionApps.IotMessageAggregator.Models;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using StackExchange.Redis;
using System;

[assembly: FunctionsStartup(typeof(Startup))]

namespace IFS.AD.FunctionApps.IotMessageAggregator
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
            builder.Services.AddOptions<AggregatorOptions>()
                .Configure<IConfiguration>((options, configuration) =>
                {
                    configuration.GetSection(nameof(AggregatorOptions)).Bind(options);
                });

            builder.Services.AddSingleton<IConnectionMultiplexer>(serviceProvider =>
            {
                var options = serviceProvider.GetRequiredService<IOptions<AggregatorOptions>>().Value;
                var configuration = ConfigurationOptions.Parse(options.RedisConnectionString);

                return ConnectionMultiplexer.Connect(configuration);
            });

            builder.Services.AddSingleton(serviceProvider =>
            {
                var options = serviceProvider.GetRequiredService<IOptions<AggregatorOptions>>().Value;
                var credential = new AzureKeyCredential(options.EventGridPublisherKey);

                return new EventGridPublisherClient(options.EventGridPublisherUri, credential);
            });
        }
    }
}
