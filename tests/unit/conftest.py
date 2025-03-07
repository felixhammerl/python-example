"""This file contains the configuration and fixtures for pytest."""

import os

import pytest


@pytest.fixture(scope="function", autouse=True)
def turn_off_aws_access():
    """This is a safeguard so that we don't accidentally use AWS resources in unit
    tests."""

    os.environ["AWS_ACCESS_KEY_ID"] = "testing"  # nosec
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"  # nosec
    os.environ["AWS_SECURITY_TOKEN"] = "testing"  # nosec
    os.environ["AWS_SESSION_TOKEN"] = "testing"  # nosec
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"  # nosec
