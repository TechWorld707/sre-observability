import os
from datetime import datetime
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from sqlalchemy import create_engine, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship, sessionmaker

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg2://minishop:minishop@postgres:5432/minishop",
)

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


class Base(DeclarativeBase):
    pass


class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    description: Mapped[str] = mapped_column(String(500), nullable=False)
    price: Mapped[float] = mapped_column(Float, nullable=False)
    image: Mapped[str] = mapped_column(String(500), nullable=False)


class Order(Base):
    __tablename__ = "orders"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    customer_name: Mapped[str] = mapped_column(String(120), nullable=False)
    customer_email: Mapped[str] = mapped_column(String(180), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    items: Mapped[List["OrderItem"]] = relationship(
        back_populates="order", cascade="all, delete-orphan"
    )


class OrderItem(Base):
    __tablename__ = "order_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    order_id: Mapped[int] = mapped_column(ForeignKey("orders.id"), nullable=False)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), nullable=False)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)

    order: Mapped[Order] = relationship(back_populates="items")


class OrderLine(BaseModel):
    product_id: int
    quantity: int = Field(gt=0, le=100)


class CreateOrder(BaseModel):
    customer_name: str = Field(min_length=2, max_length=120)
    customer_email: str = Field(min_length=5, max_length=180)
    items: List[OrderLine]


app = FastAPI(title="MiniShop API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)

    with SessionLocal() as db:
        if db.query(Product).count() == 0:
            db.add_all(
                [
                    Product(
                        name="Cloud Hoodie",
                        description="Comfortable hoodie for late-night deployments.",
                        price=39.99,
                        image="https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=800&q=80",
                    ),
                    Product(
                        name="Kubernetes Mug",
                        description="Coffee tastes better after a successful rollout.",
                        price=14.99,
                        image="https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=800&q=80",
                    ),
                    Product(
                        name="DevOps Backpack",
                        description="Carry your laptop, cables, and troubleshooting notes.",
                        price=59.99,
                        image="https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80",
                    ),
                ]
            )
            db.commit()


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/readyz")
def readyz():
    try:
        with engine.connect() as conn:
            conn.exec_driver_sql("SELECT 1")
        return {"status": "ready"}
    except Exception as exc:
        raise HTTPException(status_code=503, detail="database unavailable") from exc


@app.get("/api/products")
def list_products():
    with SessionLocal() as db:
        products = db.query(Product).order_by(Product.id).all()
        return [
            {
                "id": p.id,
                "name": p.name,
                "description": p.description,
                "price": p.price,
                "image": p.image,
            }
            for p in products
        ]


@app.post("/api/orders", status_code=201)
def create_order(payload: CreateOrder):
    if not payload.items:
        raise HTTPException(status_code=400, detail="cart is empty")

    with SessionLocal() as db:
        product_ids = [line.product_id for line in payload.items]
        products = db.query(Product).filter(Product.id.in_(product_ids)).all()
        found_ids = {p.id for p in products}

        missing = [pid for pid in product_ids if pid not in found_ids]
        if missing:
            raise HTTPException(
                status_code=400,
                detail=f"unknown product ids: {missing}",
            )

        order = Order(
            customer_name=payload.customer_name,
            customer_email=payload.customer_email,
        )
        for line in payload.items:
            order.items.append(
                OrderItem(product_id=line.product_id, quantity=line.quantity)
            )

        db.add(order)
        db.commit()
        db.refresh(order)

        return {"order_id": order.id, "status": "created"}


@app.get("/api/orders")
def list_orders():
    with SessionLocal() as db:
        orders = db.query(Order).order_by(Order.id.desc()).all()
        return [
            {
                "id": order.id,
                "customer_name": order.customer_name,
                "customer_email": order.customer_email,
                "created_at": order.created_at.isoformat(),
                "items": [
                    {
                        "product_id": item.product_id,
                        "quantity": item.quantity,
                    }
                    for item in order.items
                ],
            }
            for order in orders
        ]
