// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Azure.AI.AnomalyDetector;
using Azure;
using Spectre.Console;
using System.ComponentModel;
using System.Reflection;
using Microsoft.Extensions.Configuration;
using IFS.AD.ConsoleApps.ManageCognitiveServices;

var config = new ConfigurationBuilder().AddUserSecrets<Program>().Build();
// Use the Anomaly detector Endpoint from the service's Keys and Endpoint page
// Format: https://<ANOMALY_DETECTOR>.cognitiveservices.azure.com/
var endpoint = config.GetSection("endpoint").Value;
// Use the Anomaly detector KEY 1 or KEY 2 from the service's Keys and Endpoint page
var apiKey = config.GetSection("apiKey").Value;
// Use the URL of the blob found in the Storage browser of the Storage account
// Format: https://<BLOB_STORAGE>.blob.core.windows.net/aggregateddata/sensordata.csv
var blobStorageDataSource = config.GetSection("blobStorageDataSource").Value;

var endpointUri = new Uri(endpoint);
var credential = new AzureKeyCredential(apiKey);

var client = new AnomalyDetectorClient(endpointUri, credential);

while (true)
{
    var selection = AnsiConsole.Prompt(
        new SelectionPrompt<Choice>()
        .Title("What would you like to do?")
        .PageSize(10)
        .AddChoices(new[] {
            Choice.MultivariateListAll,
            Choice.MultivariateTrain,
            Choice.MultivariateDelete,
            Choice.Exit
        })
        .UseConverter(choice =>
        {
            var fieldInfo = choice.GetType().GetField(choice.ToString());
            var attribute = fieldInfo?.GetCustomAttribute(typeof(DescriptionAttribute)) as DescriptionAttribute;

            return attribute?.Description ?? choice.ToString();
        }));

    switch (selection)
    {
        case Choice.MultivariateListAll:
            AnsiConsole.WriteLine("Listing all...");
            var listResponse = await MultivariateModels.ListAsync(client).ConfigureAwait(false);

            AnsiConsole.WriteLine(listResponse);
            break;

        case Choice.MultivariateTrain:
            AnsiConsole.WriteLine("Training...");
            var trainingResponse = await MultivariateModels.TrainAsync(client, blobStorageDataSource).ConfigureAwait(false);

            AnsiConsole.WriteLine(trainingResponse);
            break;

        case Choice.MultivariateDelete:
            var modelId = AnsiConsole.Ask<string>("Which [green]ModelId GUID[/] would you like to delete?");

            try
            {
                AnsiConsole.WriteLine("Deleting...");
                await MultivariateModels.DeleteAsync(client, modelId).ConfigureAwait(false);

                AnsiConsole.WriteLine("Deleted");
            }
            catch (Exception ex)
            {
                AnsiConsole.WriteException(ex);
            }

            break;

        case Choice.Exit:
            return;

        default:
            AnsiConsole.WriteLine("Sorry.  We didn't understand your selection.");
            break;
    };

    AnsiConsole.WriteLine();
}
