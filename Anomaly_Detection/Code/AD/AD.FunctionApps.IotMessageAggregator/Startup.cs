// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using AD.FunctionApps.IotMessageAggregator;
using AD.FunctionApps.IotMessageAggregator.Models;
using Azure;
using Azure.Messaging.EventGrid;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using StackExchange.Redis;
using System;

[assembly: FunctionsStartup(typeof(Startup))]

namespace AD.FunctionApps.IotMessageAggregator
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
