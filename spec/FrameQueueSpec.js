describe('ObjectPool', function() {

	it('initializes its pool to null', function () {
		var queue = new ObjectPool(5),
			pool_item;
		expect(queue.pool.length).toBe(5);
		
		pool_item = queue.pool[4];
		expect(pool_item).toBe(null);
	});

	it('starts with a queue count of zero', function() {
		var queue = new ObjectPool(5);

		expect(queue.count()).toBe(0);
	});

	it('adds items to pool', function() {

	});

	it('increases queue count on add', function() {

	});

	it('decreases queue count on delete', function() {

	});

	it('reuses previous objects', function() {

	});

	it('returns an array of current items', function() {

	});

	describe('Convenience Iterator', function() {

		it('iterates items', function() {

		});

	});

	describe('Search', function() {

		it('returns false if not found', function() {

		});

		if('returns all matching objects', function() {

		});

	});

});

