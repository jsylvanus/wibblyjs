describe('FrameQueue', function() {

	it('initializes its pool to empty objects', function () {
		var queue = new FrameQueue(5),
			pool_obj;
		expect(queue.pool.length).toBe(5);
		
		pool_obj = queue.pool[4];
		expect(pool_obj.origin).toBe(null);
	});

	it('starts with a queue count of zero', function() {
		var queue = new FrameQueue(5);

		expect(queue.count()).toBe(0);
	});

});

