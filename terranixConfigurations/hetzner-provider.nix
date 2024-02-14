{
  variable."HCLOUD_TOKEN" = {
    sensitive = true;
    type = "string";
  };

  provider."hcloud".token = "\${var.HCLOUD_TOKEN}";
}
