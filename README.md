---
page_type: sample
languages:
- C#
products:
- azure-iot-hub
- azure-iot-hub-device-provisioning-service
- azure-service-bus 
- azure-data-lake-storage
- azure-logic-apps
- azure-functions-app
---

![EAE Banner](./Anomaly_Detection/Docs/Media/SA-EAE-Banner.png)

# Intelligent Field Service Solution Accelerator 

## Project Description

Field services involve tasks that are performed at the customer's location, such as installations, repairs, and maintenance. The industry has been rapidly evolving to increase efficiency and customer satisfactions by task automation. Now field service providers can bring productivity and customer experience to a new level by providing more advanced services with digitalization and cloud services such as Azure IoT Hub, Azure Data and AI services, and Azure Digital Twins. 

There are published open source projects that provide ready to deploy solutions. For example, the [Dynamics 365 Connected Field Service - Azure IoT Deployment Template](https://github.com/microsoft/Dynamics-365-Connected-Field-Service-Deployment) is a solution that uses IoT sensors and data analysis to monitor and service customers' equipment, allowing companies to detect issues remotely and dispatch technicians efficiently. It integrates with Dynamics 365 to provide a comprehensive view of customer data, service history, and technician availability. For more details, please refer to the [CFS for IoT Hub architecture and workflow description](./Anomaly_Detection/Docs/Connected_Field_Service/README.md).

The Intelligent Field Service solution accelerator builds additional AI capabilities on top of the Dynamics 365 Connected Field Service for IoT Hub. We provide multivariate anomaly detection solution that leverages [Azure Cognitive Services](https://learn.microsoft.com/en-us/azure/cognitive-services/what-are-cognitive-services) and more AI driven capabilities are planned to be released in the coming months.

## Anomaly Detection Solution Overview 

The Anomaly Detection solution detects unusual patterns or anomalies in IoT telemetry data in real time. It collects IoT telemetry data and invokes API Services provided by the [Anomaly Detector](https://learn.microsoft.com/en-us/azure/cognitive-services/anomaly-detector/overview). The Anomaly Detector uses machine learning algorithms to analyze time-series data, such as IoT telemetry, logs, and business metrics, and identify anomalies based on historical patterns and trends. Anomaly Detector also provides a confidence score to help assess the severity of the anomaly, enabling field service providers to take appropriate actions. 

To test the anomaly detection solution, we created a machine learning model using [sample IoT sensor data](./Anomaly_Detection/Deployment/Data/sensordata.csv). The machine learning model ID is plugged into an Azure Functions App called `Invoker` that interacts with the Anomaly Detector. The model can be updated with newer data when necessary. When an anomaly is detected, the `Invoker` sends message to Dynamics 365 Field service with confidence score, severity, along with actual IoT telemetry data so that appropriate action can be taken based on this message. How the action is taken can be programmed in Dynamics 365. 

Below architecture diagram illustrates the main components and information flow of this solution accelerator. The components for Anomaly Detection solution is noted in the diagram. For a description of the workflow, please refer to [anomaly detection solution architecture and workflow description](./Anomaly_Detection/Docs/README.md). 

![SA-Architecture-Anomaly-Detection](./Anomaly_Detection/Docs/Media/SA-Architecture-Anomaly-Detection-Stand-Out.png)

## Deploy and Set up the Solution Accelerator

Please refer to the [Deployment Guide](./Anomaly_Detection/Deployment/README.md) for detailed instructions on how to deploy and set up the solution. 

# Planned Future Releases

Additional solution accelerators are under construction and planned to be published in the coming months:

1. Predictive Maintenance Powered by AI
2. Digital Twins Enablement
3. Insights and Analytics

## License
MIT License

Copyright (c) Microsoft Corporation.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE

## Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks
This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

## Data Collection
The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement. Our privacy statement is located at https://go.microsoft.com/fwlink/?LinkID=824704. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
