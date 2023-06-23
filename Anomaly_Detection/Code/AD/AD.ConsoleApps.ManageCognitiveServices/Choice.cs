// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.ComponentModel;

namespace AD.ConsoleApps.ManageCognitiveServices
{
    enum Choice
    {
        [Description("List all multivariate models")]
        MultivariateListAll,
        [Description("Train a multivariate model")]
        MultivariateTrain,
        [Description("Delete a multivariate model")]
        MultivariateDelete,
        [Description("Exit")]
        Exit
    }
}
