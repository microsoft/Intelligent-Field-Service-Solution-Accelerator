// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace IFS.AD.FunctionApps.Shared.Models
{
    public class ThermostatDeviceMessage : DeviceMessage
    {
        public double Humidity { get; set; }
        public double Temperature { get; set; }
    }
}
