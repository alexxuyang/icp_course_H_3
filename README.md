# 代码设计部分

主要有两个文件，types.mo是一些类型定义，以及关于**Proposal**提议的操作函数。  

main.mo是主文件。  

```rust
  var proposals : Buffer.Buffer<Proposal> = Buffer.Buffer<Proposal>(0);
  var ownedCanisters : [Canister] = [];

  // map of ( Canister - Bool), value is true means this canister need multi-sig managed
  var ownedCanisterPermissions : HashMap.HashMap<Canister, Bool> = HashMap.HashMap<Canister, Bool>(0, func(x: Canister,y: Canister) {x==y}, Principal.hash);
  var ownerList : [Owner] = list;

  var M : Nat = m;
  var N : Nat = ownerList.size();
```

**proposals**保存了所有**提议**的列表  

**ownCanisters**保存了所有创建的**Canister**的列表

**ownedCanisterPermissions**保存了所有**Canister**的权限，canister缺省都需要多签管理。可以通过提议多人签署后，将权限移除。

**ownerList**保存了管理员列表

```rust
actor class cycle_manager(m: Nat, list: [Types.Owner]) = self {
```

首先，在```dfx deploy```时，需要传入两个参数，进行初始化：管理员Principal列表，以及阈值**M**  

阈值**M**需要大于0，小于等于Principal列表人数

任何一个管理员都可以发起提议`propose()`、或者支持提议`approve()`、或者拒绝提议`refuse()`

```rust
public type Proposal = {
    id: ID;
    proposer: Owner;
    wasm_code:  ?Blob; // valid only for install code type
    ptype: ProposalType;
    canister_id:  ?Canister; // can be null only for create canister case
    approvers: [Owner];
    refusers: [Owner];
    finished: Bool;
};
```

提议包括的数据项：
- **id**，唯一的ID
- **proposal**，提议人
- 可选的**wsm_code**
- **ptype**，提议类型
- 可选的**canister_id**
- **approvers**，已经同意该提议的管理员列表
- **refusers**，已经拒绝该提议的管理员列表
- **finished**，提议是否执行


```rust
public type ProposalType = {
    #addPermission;
    #removePermission;
    // #installCode;
    // #uninstallCode;
    #createCanister;
    // #startCanister;
    // #stopCanister;
    // #deleteCanister;
};
```

为了简化本期的实现，提议类型只包括三种：
- 为某个canister添加权限
- 为某个canister移除权限
- 创建canister

请注意，以上三个类型的议题，都需要多签才可以完成。实现了移除权限功能，是为了下一课对canister的操作而准备。


发起提议定义：
```rust
propose(ptype: ProposalType, canister_id: ?Canister, wasm_code: ?Blob) : async Proposal
```

发起提议时，需要根据提议类型，提供可选的**canister_id** 以及 **wasm_code**

当提议类型是**addPermission**时，操作目标canister需要是被多签管理的状态

当提议类型是**removePermission**时，操作目标canister需要不是被多签管理的状态

当提议类型不是创建canister时，需要提供**canister_id**

当提议类型是安装代码时，需要提供**wasm_code**；本课中传入null即可

发起提议，返回**proposal**

支持提议定义：
```rust
approve(id: ID) : async Proposal
```

支持提议时，只需提供提议**id**，返回**proposal**

提议被创建后，提议的approvers为空，发起人还需要再次调用`approve()`去支持该提议

当提议的支持者数量，达到阈值**M**后，会立即执行该提议。这部分使用到了ic management API里面的内容。具体参考[这里](https://github.com/alexxuyang/icp_course_H_3/blob/9e4dbb0ee047be8e5bd4baba214a4ac4e17006be/src/icp_course_H_3/main.mo#L144)。

拒绝提议定义：
```rust
refuse(id: ID) : async Proposal
```

拒绝提议时，只需提供提议**id**，返回**proposal**

当提议的拒绝者人数超过`N - M`时（[参考这里](https://github.com/alexxuyang/icp_course_H_3/blob/9e4dbb0ee047be8e5bd4baba214a4ac4e17006be/src/icp_course_H_3/main.mo#L108)），该提议将会终止。

