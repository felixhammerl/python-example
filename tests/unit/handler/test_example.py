"""Unit tests for the example handler."""

# pyright: reportWildcardImportFromLibrary=false
# pylint: disable=wildcard-import, unused-wildcard-import
import os
import subprocess  # nosec

import pytest
import yaml
from hamcrest import *

import example.handler.example as handler


@pytest.fixture(name="secret_foo")
def extract_secret_foo():
    """Automatically loads secrets from Mozilla SOPS for tests."""

    encrypted_secrets = "secrets.local.yaml"
    sops_file = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..", "..", "..", encrypted_secrets)
    )

    result = subprocess.run(  # nosec
        ["sops", "--decrypt", sops_file], capture_output=True, text=True, check=True
    )

    secrets = yaml.safe_load(result.stdout)
    return str(secrets["foo"])


def test_should_run_handler(secret_foo):
    """Test that the handler runs without error."""

    event = {"foo": secret_foo}

    expected_message = "Hello, World!"
    actual_message = handler.do_stuff(event, None)
    assert_that(actual_message, equal_to(expected_message))
