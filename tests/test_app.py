from app import create_app


def test_health_endpoint():
    client = create_app().test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_index_endpoint():
    client = create_app().test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert response.get_json()["message"] == "DevOps team lab"
def test_intentional_failure();
    assert 1 == 2
