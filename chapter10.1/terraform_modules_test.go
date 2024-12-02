package test

import (
	"bytes"
	"fmt"
	"net/http"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformModule(t *testing.T) {

	terraformVars := map[string]interface{}{
		"bucket_name": "terraform-test-bucket-jl",
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./testfixtures",
		Vars:         terraformVars,
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	endpoint := terraform.Output(t, terraformOptions, "endpoint")
	url := fmt.Sprintf("http://%s", endpoint)
	resp, err := http.Get(url)
	if err != nil {
		t.Error(err)
	}

	buf := new(bytes.Buffer)
	buf.ReadFrom(resp.Body)
	t.Logf("\n%s", buf.String())
	if resp.StatusCode != http.StatusOK {
		t.Errorf("status code did not return 200")
	}
}
