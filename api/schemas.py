from pydantic import BaseModel
from typing import Optional

# Schema base com os campos comuns
class VehicleBase(BaseModel):
    model: str
    year: int
    price: float
    description: Optional[str] = None

# Schema para a criação de um novo veículo (usado no POST)
class VehicleCreate(VehicleBase):
    pass

# Schema para a leitura de um veículo (usado no GET, inclui campos do DB)
class Vehicle(VehicleBase):
    id: int
    brand: str
    image_url_1: Optional[str] = None
    image_url_2: Optional[str] = None

    class Config:
        from_attributes = True