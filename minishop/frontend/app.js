const productsEl = document.getElementById("products");
const statusEl = document.getElementById("status");
const cartCountEl = document.getElementById("cartCount");
const cartButton = document.getElementById("cartButton");
const cartDialog = document.getElementById("cartDialog");
const cartItemsEl = document.getElementById("cartItems");
const checkoutForm = document.getElementById("checkoutForm");
const checkoutMessage = document.getElementById("checkoutMessage");

let products = [];
const cart = new Map();

function money(value) {
  return new Intl.NumberFormat("en-GB", {
    style: "currency",
    currency: "GBP",
  }).format(value);
}

function renderProducts() {
  productsEl.innerHTML = products.map(product => `
    <article class="card">
      <img src="${product.image}" alt="${product.name}" />
      <div class="card-body">
        <h3>${product.name}</h3>
        <p>${product.description}</p>
        <div class="card-footer">
          <strong>${money(product.price)}</strong>
          <button onclick="addToCart(${product.id})">Add to cart</button>
        </div>
      </div>
    </article>
  `).join("");
}

function renderCart() {
  const rows = [...cart.entries()].map(([productId, quantity]) => {
    const product = products.find(p => p.id === productId);
    return `
      <div class="cart-row">
        <span>${product.name}</span>
        <span>x${quantity}</span>
        <strong>${money(product.price * quantity)}</strong>
      </div>
    `;
  });

  cartItemsEl.innerHTML = rows.length
    ? rows.join("")
    : "<p>Your cart is empty.</p>";

  cartCountEl.textContent = [...cart.values()]
    .reduce((sum, quantity) => sum + quantity, 0);
}

window.addToCart = function addToCart(productId) {
  cart.set(productId, (cart.get(productId) || 0) + 1);
  renderCart();
};

cartButton.addEventListener("click", () => {
  renderCart();
  cartDialog.showModal();
});

checkoutForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  checkoutMessage.textContent = "";

  if (cart.size === 0) {
    checkoutMessage.textContent = "Add at least one product.";
    return;
  }

  const body = {
    customer_name: document.getElementById("customerName").value,
    customer_email: document.getElementById("customerEmail").value,
    items: [...cart.entries()].map(([product_id, quantity]) => ({
      product_id,
      quantity,
    })),
  };

  const response = await fetch("/api/orders", {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(body),
  });

  const result = await response.json();

  if (!response.ok) {
    checkoutMessage.textContent = result.detail || "Order failed.";
    return;
  }

  checkoutMessage.textContent = `Order #${result.order_id} created successfully.`;
  cart.clear();
  renderCart();
  checkoutForm.reset();
});

async function loadProducts() {
  try {
    statusEl.textContent = "Loading...";
    const response = await fetch("/api/products");
    if (!response.ok) throw new Error("API unavailable");
    products = await response.json();
    renderProducts();
    statusEl.textContent = `${products.length} products available`;
  } catch (error) {
    statusEl.textContent = "Unable to load products";
    productsEl.innerHTML = `
      <div class="error">
        Backend is unavailable. This is a useful Kubernetes troubleshooting scenario.
      </div>
    `;
  }
}

loadProducts();
