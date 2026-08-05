from pydantic import BaseModel


class Item(BaseModel):
    id: int
    name: str
    price: float
    in_stock: bool
    quantity: int