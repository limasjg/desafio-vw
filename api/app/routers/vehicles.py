from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional

from .. import crud, models, schemas
from ..database import get_db
from ..services.storage_service import save_file

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
    try:
        for image in images:
            url = save_file(image)
            image_urls.append(url)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    vehicle_data = schemas.VehicleCreate(model=model, year=year, price=price, description=description)
    return crud.create_vehicle(db=db, vehicle=vehicle_data, image_urls=image_urls)

@router.get("/", response_model=List[schemas.Vehicle])
def read_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_vehicles(db, skip=skip, limit=limit)

@router.get("/{vehicle_id}", response_model=schemas.Vehicle)
def read_vehicle(vehicle_id: int, db: Session = Depends(get_db)):
    db_vehicle = crud.get_vehicle(db, vehicle_id=vehicle_id)
    if db_vehicle is None:
        raise HTTPException(status_code=404, detail="Veículo não encontrado")
    return db_vehicle