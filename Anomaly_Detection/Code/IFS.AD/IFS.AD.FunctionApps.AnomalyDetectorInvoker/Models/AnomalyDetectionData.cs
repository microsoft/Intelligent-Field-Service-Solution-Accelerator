// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace IFS.AD.FunctionApps.AnomalyDetectorInvoker.Models
{
    public class AnomalyDetectionData : AlertData
    {
        public float Score { get; set; }
        public float Severity { get; set; }

        public AnomalyDetectionData(object reading, string readingType, string ruleOutput) :
            base(reading, readingType, ruleOutput)
        {
        }
    }
}
