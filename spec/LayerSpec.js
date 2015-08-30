describe('Layer',function() {
	
	it('constructs with values', function() {
		var construct = function() {
			var layer = new BigSea.Layer(0, 0, 100, 100);
		};

		expect(construct).not.toThrow();
	});

	it('constructs without values', function() {
		var construct = function() {
			var layer = new BigSea.Layer();
		};

		expect(construct).not.toThrow();
	});

	describe('Properties',function() {
		
		var test_layer;

		beforeEach(function() {
			test_layer = new BigSea.Layer(0, 5, 200, 100);
		});

		it('origin is a vector', function() {
			expect(test_layer.origin instanceof Vector).toBe(true);
			expect(test_layer.origin.x()).toBe(0);
			expect(test_layer.origin.y()).toBe(5);
		});

		it('box is a dimensions object', function() {
			expect(test_layer.box instanceof Dimensions).toBe(true);
			expect(test_layer.box.width()).toBe(200);
			expect(test_layer.box.height()).toBe(100);
		});
			
	});

	describe('Methods', function() {
		
		var test_layer;

		beforeEach(function() {
			test_layer = new BigSea.Layer(0, 5, 200, 100);
		});
		
		it('has convenience methods', function() {
			expect(test_layer.left()).toBe(0);
			expect(test_layer.top()).toBe(5);
			expect(test_layer.width()).toBe(200);
			expect(test_layer.height()).toBe(100);
			expect(test_layer.bottom()).toBe(105);
			expect(test_layer.right()).toBe(200);
		});

		describe('Equals',function() {

			var inequal, equal;

			beforeEach(function() {
				equal = new BigSea.Layer(0, 5, 200, 100);
				inequal = new BigSea.Layer(10, 50, 1000, 2000);
			});

			it('returns true for matching', function() {
				expect(test_layer.is_equal_to(equal)).toBe(true);
			});

			it('returns false for non-matching', function() {
				expect(test_layer.is_equal_to(inequal)).toBe(false);
			})

		});

		describe('Equivalent',function() {
			
			var equiv_layer, inequiv_layer;

			beforeEach(function() {
				// only w/h match test_layer
				equiv_layer = new BigSea.Layer(100, 500, 200, 100);
				inequiv_layer = new BigSea.Layer(100, 500, 400, 200);
			});

			it('returns true for same dimensions', function() {
				expect(test_layer.is_equivalent_to(equiv_layer)).toBe(true);
			});

			it('returns false for different dimensions', function() {
				expect(test_layer.is_equivalent_to(inequiv_layer)).toBe(false);
			});

		});

		describe('Intersects',function() {
			var inside, outside, around, touching;

			beforeEach(function() {
				inside = new BigSea.Layer(2, 7, 100, 50);
				outside = new BigSea.Layer(300, 120, 50, 50);
				around = new BigSea.Layer(-5, -5, 300, 200);
				touching = new BigSea.Layer(50, 50, 400, 200);
			});

			it('returns true if layer intersects at all', function() {
				expect(test_layer.intersects(test_layer)).toBe(true);
				expect(test_layer.intersects(inside)).toBe(true);
				expect(test_layer.intersects(around)).toBe(true);
				expect(test_layer.intersects(touching)).toBe(true);
			});

			it('returns false otherwise', function() {
				expect(test_layer.intersects(outside)).toBe(false);
			});
			
		});

		describe('Contains',function() {
			
			var inside, outside, around;

			beforeEach(function() {
				inside = new BigSea.Layer(2, 7, 100, 50);
				outside = new BigSea.Layer(300, 120, 50, 50);
				around = new BigSea.Layer(-5, -5, 300, 200);
			});

			it('returns true if other is same', function() {
				expect(test_layer.contains(test_layer)).toBe(true);
			});

			it('returns true if other is completely inside', function() {
				expect(test_layer.contains(inside)).toBe(true);
			});

			it('returns false otherwise', function() {
				expect(test_layer.contains(outside)).toBe(false);
				expect(test_layer.contains(around)).toBe(false);
			});

		});

	});

});
