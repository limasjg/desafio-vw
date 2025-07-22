from sqlalchemy import Column, Integer, String, Float
from .database import Base

class Vehicle(Base):
    __tablename__ = "vehicles"

    id = Column(Integer, primary_key=True, index=True)
    model = Column(String, index=True)
    brand = Column(String, default="Volkswagen")
    year = Column(Integer)
    price = Column(Float)
    description = Column(String)
    image_url_1 = Column(String, nullable=True)
    image_url_2 = Column(String, nullable=True)