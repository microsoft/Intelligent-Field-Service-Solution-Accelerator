// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace AD.FunctionApps.AnomalyDetectorInvoker.Models
{
    public class InvokerOptions
    {
        public string AnomalyDetectorKey { get; set; }
        public Guid AnomalyDetectorModelId { get; set; }
        public Uri AnomalyDetectorUri { get; set; }
        public string ServiceBusConnectionString { get; set; }
        public string ServiceBusQueueName { get; set; }
    }
}
