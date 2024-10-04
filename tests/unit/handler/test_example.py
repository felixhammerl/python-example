"""Unit tests for the example handler."""

# pyright: reportWildcardImportFromLibrary=false
# pylint: disable=wildcard-import, unused-wildcard-import
from hamcrest import *

import example.handler.example as handler


def test_should_run_handler():
    """Test that the handler runs without error."""
    expected_message = "Hello, World!"
    actual_message = handler.do_stuff(None, None)
    assert_that(actual_message, equal_to(expected_message))
