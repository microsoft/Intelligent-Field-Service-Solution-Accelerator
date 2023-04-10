// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace IFS.AD.FunctionApps.AnomalyDetectorInvoker.Models
{
    public class ThermostatAnomalyDetectionData : AnomalyDetectionData
    {
        public double Humidity { get; set; }
        public double Temperature { get; set; }

        public ThermostatAnomalyDetectionData(object reading, string readingType, string ruleOutput) :
            base(reading, readingType, ruleOutput)
        {
        }
    }
}
