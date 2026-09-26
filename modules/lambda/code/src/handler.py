import sys
import json
from os import environ, getenv
from typing import Any, Dict
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from common import aws_helper


logger = Logger()

try:
    # Globally scoped variables and resources
    logger.debug("Initialize the resources once per Lambda execution environment by using global scope")
    _SCHEDULE_TAG_NAME = environ["SCHEDULE_TAG_NAME"]

except Exception as e:
    logger.error("Unexpected error: Could not access environment variables or secrets.")
    logger.error(e)
    sys.exit()

@logger.inject_lambda_context
def scheduler_handler(event, context):
    """
    This function demonstrates basic lambda handler
    """

    logger.info("It works!")
    
    response = {
                   "result": True,
                   "schedule_tag_name": _SCHEDULE_TAG_NAME,
               }
    return response
