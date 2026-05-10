# 4.5 Code Scheduling

## Exam Facts

- ==**Code scheduling**==: reorder instructions to reduce stalls while preserving dependencies.
- True dependence = **RAW**.
- Legal schedule = any **topological order** of dependence DAG.
- Critical path = longest weighted path; schedule critical-path nodes early.
- Compiler scheduling is limited by **memory aliasing** and unknown/non-deterministic memory latency.
- Data hazards can be reduced by **data forwarding, OoO execution, compiler scheduling**.

## Dependencies

| Type | Meaning | Must Preserve? |
|---|---|---|
| ==**RAW**== | read after write; true flow dependence | yes |
| ==**WAR**== | write after read; anti-dependence | yes for reordering/OoO |
| ==**WAW**== | write after write; output dependence | yes for final value |
| RAR | read after read | no dependence |

- RAW latency is usually operation latency.
- WAR/WAW often order-only in in-order issue, but constrain compiler schedules.
- Memory dependencies are conservative if addresses may alias.

## Dependence DAG

- Node = instruction.
- Edge `A -> B` means A must be scheduled before B.
- Edge weight = latency gap required before B can use A's result.
- Legal schedule respects every edge.
- Better schedule reduces bubbles by placing independent instructions in latency gaps.

## Operation Latency / Critical Path

- Arc weight is operation latency; multiply often > ALU; load latency depends on memory/cache.
- Node priority = max delay from node to exit (reverse topological).
- Schedule high-priority ready nodes early.
- Exhaustive scheduling is infeasible (`N!` schedules); use heuristics/list scheduling.

## List Scheduling

Algorithm:
1. build DAG and predecessor counts;
2. maintain ready set = nodes with no unscheduled predecessors;
3. choose best ready node (critical path / latency / resource heuristic);
4. issue it, update successors when latency/order constraints satisfied;
5. repeat.

Common heuristics: critical-path priority, longer latency first, resource pressure, original order as tie-breaker.

## Memory Dependence / Aliasing

- If compiler cannot prove two memory refs do not alias, it must keep conservative order.
- Pointer aliasing and unknown array indices block scheduling/vectorization.
- `restrict`, local scalar copies, and better data layout can expose independence.

## Quiz Scheduling Pattern

- With no forwarding: count bubbles until producer WB.
- With forwarding: ALU result can forward EX/MEM or MEM/WB; load-use often leaves 1 bubble.
- To reduce bubbles, move independent loads/ALU ops between producer and consumer.
- Do not move later loads before a store if addresses may alias with that store.
