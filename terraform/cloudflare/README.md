# DNS

## Host records (A) naming convention

### 🔧 **Top-Level Naming Scheme**

`<site>-<role>-<id>.jakerob.pro`

`<site>-<role>-<id>.vpn.jakerob.pro` (for VPN-accessible nodes)

### 🖥️ **Roles and Conventions**

#### **Hypervisors**

Use the role: `hv`
(e.g., `lhr1-hv-1.jakerob.pro`)

If I ever scale to multiple hypervisors per site, `-1` allows easy indexing.

**Example:**

* `lhr1-hv-1.jakerob.pro`
* `lhr1-hv-1.vpn.jakerob.pro`

---

#### **VMs**

Use the role: `vm`
(e.g., `lhr1-vm-1.jakerob.pro`)

**Example:**

* `lhr1-vm-1.jakerob.pro`
* `iad1-vm-3.jakerob.pro`
* `slc1-vm-2.jakerob.pro`

---

#### **Storage Nodes**

Use the role: `storage`
(e.g., `lhr1-storage-1.jakerob.pro`)

**Example:**

* `sgu1-storage-1.jakerob.pro`

---

#### **Raspberry Pis**

Use the role: `pi`
(e.g., `lhr1-pi-1.jakerob.pro`)

**Example:**

* `slc1-pi-1.jakerob.pro`
* `sgu1-pi-2.jakerob.pro`

---

#### **VPN Access**

Just copy the FQDN and change the root domain:

* `lhr1-hv-1.jakerob.pro` → `lhr1-hv-1.vpn.jakerob.pro`

---

### 💡 Summary

| Role         | Example                      | Notes                             |
| ------------ | ---------------------------- | --------------------------------- |
| Hypervisor   | `lhr1-hv-1.jakerob.pro`      | Consistent index for future scale |
| VM           | `lhr1-vm-2.jakerob.pro`      |               |
| Storage Node | `lhr1-storage-1.jakerob.pro` |                   |
| Raspberry Pi | `lhr1-pi-1.jakerob.pro`      |             |
| VPN Access   | `*.vpn.jakerob.pro`          | Just mirror the base FQDN         |
