_: {
  config = {
    sys.cloud = {
      enable = true;

      config.xdg.enable = true;

      aws = {
        enable = true;

        profiles.default.region = "us-east-1";
      };

      azure.enable = true;
    };

    nmt.script = ''
      awsDir="home-files/.aws"
      assertDirectoryNotEmpty "$awsDir"
      assertFileExists "$awsDir/config"
      assertFileContains "$awsDir/config" 'region=us-east-1'

      azureDir="home-files/.azure"
      assertDirectoryNotEmpty "$azureDir"
      assertFileExists "$azureDir/config"
      assertFileContains "$azureDir/config" 'location=eastus'
    '';
  };
}
