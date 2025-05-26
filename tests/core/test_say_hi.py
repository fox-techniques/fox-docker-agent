from src.fox_pypi import hello


def test_hello():
    assert hello("Ali") == "Hello, Ali!"
