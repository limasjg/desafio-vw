from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional

from .. import crud, models, schemas
from ..database import get_db
from ..services.s3_service import upload_file_to_s3

router = APIRouter(
    prefix="/vehicles",
    tags=["vehicles"],
)

@router.post("/", response_model=schemas.Vehicle)
def create_new_vehicle(
    model: str = Form(...),
    year: int = Form(...),
    price: float = Form(...),
    description: Optional[str] = Form(None),
    images: List[UploadFile] = File(...),
    db: Session = Depends(get_db)
):
    if len(images) > 2:
        raise HTTPException(status_code=400, detail="É permitido no máximo 2 imagens por veículo.")

    image_urls = []
    for image in images:
        # Gera um nome de arquivo único para evitar sobreposições
        file_name = f"vehicles/{image.filename}" 
        url = upload_file_to_s3(image, file_name)
        image_urls.append(url)

    vehicle_data = schemas.VehicleCreate(model=model, year=year, price=price, description=description)
    return crud.create_vehicle(db=db, vehicle=vehicle_data, image_urls=image_urls)

@router.get("/", response_model=List[schemas.Vehicle])
def read_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    vehicles = crud.get_vehicles(db, skip=skip, limit=limit)
    return vehicles

@router.get("/{vehicle_id}", response_model=schemas.Vehicle)
def read_vehicle(vehicle_id: int, db: Session = Depends(get_db)):
    db_vehicle = crud.get_vehicle(db, vehicle_id=vehicle_id)
    if db_vehicle is None:
        raise HTTPException(status_code=404, detail="Veículo não encontrado")
    return db_vehicle