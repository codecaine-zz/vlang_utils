module structutils

fn test_stack() {
	mut s := new_stack[string]()
	assert s.is_empty()
	assert s.len() == 0

	s.push('first')
	s.push('second')
	s.push('third')

	assert s.len() == 3
	assert s.peek() or { '' } == 'third'

	pop1 := s.pop() or { '' }
	assert pop1 == 'third'
	assert s.len() == 2

	pop2 := s.pop() or { '' }
	assert pop2 == 'second'

	s.clear()
	assert s.is_empty()
	assert s.pop() == none
}

fn test_queue() {
	mut q := new_queue[int]()
	assert q.is_empty()

	q.push(10)
	q.push(20)
	q.push(30)

	assert q.len() == 3
	assert q.peek() or { 0 } == 10

	out1 := q.pop() or { 0 }
	assert out1 == 10
	assert q.len() == 2

	out2 := q.pop() or { 0 }
	assert out2 == 20
}

fn test_ring_buffer() {
	mut r := new_ring_buffer[string](3)
	assert r.capacity == 3
	assert r.is_empty()

	r.push('A')
	r.push('B')
	r.push('C')
	assert r.is_full()
	assert r.len() == 3

	// Pushing when full should drop the oldest ('A')
	r.push('D')
	assert r.len() == 3
	assert r.get(0) or { '' } == 'B'
	assert r.get(1) or { '' } == 'C'
	assert r.get(2) or { '' } == 'D'

	pop_b := r.pop() or { '' }
	assert pop_b == 'B'
	assert r.len() == 2
}

fn test_min_heap() {
	mut h := new_min_heap()
	assert h.is_empty()

	h.push(42.0)
	h.push(12.5)
	h.push(99.0)
	h.push(5.0)

	assert h.len() == 4
	assert h.peek() or { 0.0 } == 5.0

	assert h.pop() or { 0.0 } == 5.0
	assert h.pop() or { 0.0 } == 12.5
	assert h.pop() or { 0.0 } == 42.0
	assert h.pop() or { 0.0 } == 99.0
	assert h.is_empty()
}
