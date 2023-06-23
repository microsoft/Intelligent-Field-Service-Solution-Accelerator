// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace AD.FunctionApps.IotMessageAggregator.Models
{
    public class AggregatorOptions
    {
        public int AnomalyDetectorSlidingWindow { get; set; }
        public string EventGridPublisherKey { get; set; }
        public Uri EventGridPublisherUri { get; set; }
        public string RedisConnectionString { get; set; }
    }
}
