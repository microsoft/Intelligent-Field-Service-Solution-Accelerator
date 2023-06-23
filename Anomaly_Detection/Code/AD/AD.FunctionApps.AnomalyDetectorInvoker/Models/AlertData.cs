// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace AD.FunctionApps.AnomalyDetectorInvoker.Models
{
    public class AlertData
    {
        public string DeviceId { get; set; }
        public string EventToken { get; set; }
        public object Reading { get; set; }
        public string ReadingType { get; set; }
        public string RuleOutput { get; set; }
        public string Time { get; set; }

        public AlertData(object reading, string readingType, string ruleOutput)
        {
            // These are the required fields if you click Next > Next > Next while configuring IoT alert AI suggestions
            // https://learn.microsoft.com/en-us/dynamics365/field-service/iot-alerts-ai-based-suggestions
            Reading = reading;
            ReadingType = readingType;
            RuleOutput = ruleOutput;
        }
    }
}
