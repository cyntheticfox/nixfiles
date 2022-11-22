{ lib, ... }:

with lib;

{
  config = {
    sys.cloud = {
      enable = true;

      config.xdg.enable = true;

      manageAwsConfig = true;
      manageAzureConfig = true;
    };

    nmt.script = ''
      awsDir="home-files/.aws"
      assertDirectoryNotEmpty "$awsDir"
      assertFileExists "$awsDir/config"
      assertFileContains "$awsDir/config" 'region = us-east-1'

      azureDir="home-files/.azure"
      assertDirectoryNotEmpty "$azureDir"
      assertFileExists "$azureDir/config"
      assertFileContains "$azureDir/config" 'location=eastus'
    '';
  };
}

