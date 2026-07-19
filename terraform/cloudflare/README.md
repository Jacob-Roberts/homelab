# DNS

## Host records (A) naming convention

### 🔧 **Top-Level Naming Scheme**

`<site>-<role>-<id>.jakerob.pro`

`<site>-<role>-<id>.vpn.jakerob.pro` (for VPN-accessible nodes)

### 🖥️ **Roles and Conventions**

#### **Hypervisors**

Use the role: `hv`
(e.g., `pbj-hv-1.jakerob.pro`)

If I ever scale to multiple hypervisors per site, `-1` allows easy indexing.

**Example:**

* `pbj-hv-1.jakerob.pro`
* `pbj-hv-1.vpn.jakerob.pro`

---

#### **VMs**

Use the role: `vm`
(e.g., `pbj-vm-1.jakerob.pro`)

**Example:**

* `pbj-vm-1.jakerob.pro`
* `iad1-vm-3.jakerob.pro`
* `slc1-vm-2.jakerob.pro`

---

#### **Storage Nodes**

Use the role: `storage`
(e.g., `pbj-storage-1.jakerob.pro`)

**Example:**

* `sgu1-storage-1.jakerob.pro`

---

#### **Raspberry Pis**

Use the role: `pi`
(e.g., `pbj-pi-1.jakerob.pro`)

**Example:**

* `slc1-pi-1.jakerob.pro`
* `sgu1-pi-2.jakerob.pro`

---

#### **VPN Access**

Just copy the FQDN and change the root domain:

* `pbj-hv-1.jakerob.pro` → `pbj-hv-1.vpn.jakerob.pro`

---

### 💡 Summary

| Role         | Example                      | Notes                             |
| ------------ | ---------------------------- | --------------------------------- |
| Hypervisor   | `pbj-hv-1.jakerob.pro`      | Consistent index for future scale |
| VM           | `pbj-vm-2.jakerob.pro`      |               |
| Storage Node | `pbj-storage-1.jakerob.pro` |                   |
| Raspberry Pi | `pbj-pi-1.jakerob.pro`      |             |
| VPN Access   | `*.vpn.jakerob.pro`          | Just mirror the base FQDN         |
