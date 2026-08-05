import json
import random
import string
from pathlib import Path
from models.schema import Item

DATA_FILE = Path("data.json")


def read_data():
    """Read data from json file. Returns empty list if file doesn't exist."""
    if not DATA_FILE.exists():
        return []
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def write_data(data):
    """Write data to json file."""
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def random_string(length=6):
    return "".join(random.choices(string.ascii_letters, k=length))


def generate_random_item(item_id: int) -> Item:
    return Item(
        id=item_id,
        name=random_string(8),
        price=round(random.uniform(10, 500), 2),
        in_stock=random.choice([True, False]),
        quantity=random.randint(0, 100),
    )


def create_random_items(count: int = 5):
    """Generate random items and overwrite the json file."""
    items = [generate_random_item(i).model_dump() for i in range(1, count + 1)]
    write_data(items)
    return items


def get_all_items():
    return read_data()