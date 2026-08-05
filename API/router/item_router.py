from fastapi import APIRouter
from controllers.item_controller import get_all_items, create_random_items

router = APIRouter(prefix="/items", tags=["items"])


@router.get("/")
def list_items():
    return get_all_items()


@router.post("/random")
def generate_items(count: int = 5):
    return create_random_items(count)