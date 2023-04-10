// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Azure.AI.AnomalyDetector;

namespace IFS.AD.ConsoleApps.ManageCognitiveServices
{
    static class MultivariateModels
    {
        internal static async Task<string> ListAsync(AnomalyDetectorClient client)
        {
            var modelDetails = new List<string>();

            var models = client.GetMultivariateModelValuesAsync().ConfigureAwait(false);

            await foreach (var model in models)
            {
                var modelDetail = new[]
                {
                    $"{nameof(model.ModelId)}: {model.ModelId}",
                    $"{nameof(model.CreatedTime)}: {model.CreatedTime}",
                    $"{nameof(model.LastUpdatedTime)}: {model.LastUpdatedTime}",
                    $"{nameof(model.ModelInfo.Status)}: {model.ModelInfo.Status}"
                };

                modelDetails.Add(string.Join(", ", modelDetail));
            }

            return string.Join(Environment.NewLine, modelDetails);
        }

        internal static async Task<string> TrainAsync(AnomalyDetectorClient client, string dataSource)
        {
            var startTime = new DateTimeOffset(
                year: 2023,
                month: 01,
                day: 10,
                hour: 21,
                minute: 35,
                second: 06,
                millisecond: 663,
                offset: new TimeSpan());
            var endTime = new DateTimeOffset(
                year: 2023,
                month: 01,
                day: 12,
                hour: 14,
                minute: 35,
                second: 44,
                millisecond: 849,
                offset: new TimeSpan());

            var modelInfo = new ModelInfo(dataSource, startTime, endTime)
            {
                DataSchema = DataSchema.OneTable,
                SlidingWindow = 28
            };
            var response = await client.TrainMultivariateModelAsync(modelInfo).ConfigureAwait(false);

            var modelDetails = new[]
            {
                $"{nameof(response.Value.ModelId)}: {response.Value.ModelId}",
                $"{nameof(response.Value.CreatedTime)}: {response.Value.CreatedTime}",
                $"{nameof(response.Value.LastUpdatedTime)}: {response.Value.LastUpdatedTime}",
                $"{nameof(response.Value.ModelInfo.Status)}: {response.Value.ModelInfo.Status}"
            };

            return string.Join(", ", modelDetails);
        }

        internal static async Task DeleteAsync(AnomalyDetectorClient client, string modelId) =>
            await client.DeleteMultivariateModelAsync(modelId).ConfigureAwait(false);
    }
}
