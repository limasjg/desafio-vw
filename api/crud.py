from sqlalchemy.orm import Session
from . import models, schemas

def get_vehicle(db: Session, vehicle_id: int):
    return db.query(models.Vehicle).filter(models.Vehicle.id == vehicle_id).first()

def get_vehicles(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Vehicle).offset(skip).limit(limit).all()

def create_vehicle(db: Session, vehicle: schemas.VehicleCreate, image_urls: list[str] = []):
    db_vehicle = models.Vehicle(
        **vehicle.model_dump(),
        image_url_1=image_urls[0] if len(image_urls) > 0 else None,
        image_url_2=image_urls[1] if len(image_urls) > 1 else None
    )
    db.add(db_vehicle)
    db.commit()
    db.refresh(db_vehicle)
    return db_vehicle