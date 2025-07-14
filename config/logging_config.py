"""
#! DEV VERSION
Centralized logging configuration for the vocalassistant-core project.

This module provides a consistent logging setup that can be imported
by all modules in the project.

Usage:
    from config.logging_config import setup_logging

    # At the beginning of your module:
    logger = setup_logging(__name__)

    # Then use logger as normal:
    logger.info("This is an info message")
    logger.warning("This is a warning")
    logger.error("This is an error")
"""

import logging
import sys

from colorama import Fore, Style, init

# Initialize colorama
init(autoreset=True)

# Define color formatter
class ColorFormatter(logging.Formatter):
    FORMATS = {
        logging.DEBUG: Fore.CYAN + "%(asctime)s - %(filename)s - %(levelname)s - %(message)s" + Style.RESET_ALL,
        logging.INFO: Fore.GREEN + "%(asctime)s - %(filename)s - %(levelname)s - %(message)s" + Style.RESET_ALL,
        logging.WARNING: Fore.YELLOW + "%(asctime)s - %(filename)s - %(levelname)s - %(message)s" + Style.RESET_ALL,
        logging.ERROR: Fore.RED + "%(asctime)s - %(filename)s - %(levelname)s - %(message)s" + Style.RESET_ALL,
        logging.CRITICAL: Fore.RED + Style.BRIGHT + "%(asctime)s - %(filename)s - %(levelname)s - %(message)s" + Style.RESET_ALL
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_fmt)
        return formatter.format(record)

def setup_logging(module_name: str, log_level: int | None = None) -> logging.Logger:
    """
    Set up and return a logger with the specified name and configuration.

    Args:
        module_name: Name of the module (typically __name__)
        log_level: Optional override for log level (defaults to INFO)

    Returns:
        Configured logger instance
    """
    # Only configure root logger once
    if not logging.getLogger().handlers:
        # Default level is INFO unless overridden
        default_level = log_level if log_level is not None else logging.INFO

        # Create console handler with color formatter
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setFormatter(ColorFormatter())

        # Configure the root logger
        root_logger = logging.getLogger()
        root_logger.setLevel(default_level)
        root_logger.addHandler(console_handler)

        # Optionally add file handler if LOG_DIR is defined
        # This could be expanded to read from your config.ini
        # log_dir = os.environ.get('LOG_DIR')
        # if log_dir and os.path.exists(log_dir):
        #     file_handler = logging.FileHandler(
        #         os.path.join(log_dir, 'vocalassistant.log')
        #     )
        #     file_handler.setFormatter(logging.Formatter(
        #         '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        #     ))
        #     logging.getLogger().addHandler(file_handler)

    # Get the logger for this module
    logger = logging.getLogger(module_name)

    # Override level if specified
    if log_level is not None:
        logger.setLevel(log_level)

    return logger
