import pytest


@pytest.fixture(scope="session")
def dummy_resource():
    """Initialize dummy resource for dummy test"""

    return "dummy"
    

def test_dummy_resource(dummy_resource):

    # Ensure dummy is initialized before testing
    assert dummy_resource == "dummy"