"""This module contains the configuration for the application.

The configuration is loaded from a JSON file based on the environment variable STAGE.
"""

import json
import os
from dataclasses import dataclass

from dacite import from_dict


@dataclass(frozen=True)
class Logging:
    """Configuration for logging."""

    log_level: str


@dataclass(frozen=True)
class Config:
    """Configuration for the application."""

    logging: Logging


def load():
    """Load the configuration from a JSON file based on the environment variable
    STAGE."""
    base_path = os.path.abspath(os.path.dirname(__file__))
    env = os.environ.get("STAGE", "local")
    config_path = os.path.join(base_path, f"{env}.json")
    with open(file=config_path, mode="r", encoding="utf-8") as f:
        data = json.loads(f.read())
    return from_dict(data_class=Config, data=data)


config = load()
