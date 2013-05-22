/**
 * SemVer.as (v0.0.1)
 * https://github.com/creativemarket/as3-semver
 *
 * See http://semver.org/
 * This implementation is a *hair* less strict in that it allows
 * v1.2.3 things, and also tags that don't begin with a char.
 *
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * @author Brian Reavis <brian@creativemarket.com>
 */

package {

	public class SemVer {

		// expressions
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		private static const REGEX_SEMVER:String =
			"\\s*[v=]*\\s*([0-9]+)" +
			"\\.([0-9]+)" +
			"\\.([0-9]+)" +
			"(-[0-9]+-?)?" +
			"([a-zA-Z-+][a-zA-Z0-9-\.:]*)?";

		private static const REGEX_XRANGE_PLAIN:String =
			"[v=]*([0-9]+|x|X|\\*)" +
			"(?:\\.([0-9]+|x|X|\\*)" +
			"(?:\\.([0-9]+|x|X|\\*)" +
			"([a-zA-Z-][a-zA-Z0-9-\.:]*)?)?)?";

		private static const REGEX_EXPR_COMPARATOR:String = "^((<|>)?=?)\s*(" + REGEX_SEMVER + ")$|^$";
		private static const REGEX_XRANGE:String = "((?:<|>)=?)?\\s*" + REGEX_XRANGE_PLAIN;
		private static const REGEX_EXPR_LONE_SPERMY:String = "(?:~>?)";
		private static const REGEX_EXPR_SPERMY:String = REGEX_EXPR_LONE_SPERMY + REGEX_XRANGE;

		private static const RANGE_REPLACE:String = ">=$1 <=$7";

		public static var expressions:Object = {
			parse           : new RegExp("^\\s*" + REGEX_SEMVER + "\\s*$"),
			parsePackage    : new RegExp("^\\s*([^\/]+)[-@]("  + REGEX_SEMVER + ")\\s*$"),
			parseRange      : new RegExp("^\\s*(" + REGEX_SEMVER + ")\\s+-\\s+(" + REGEX_SEMVER + ")\\s*$"),
			validComparator : new RegExp("^" + REGEX_EXPR_COMPARATOR + "$"),
			parseXRange     : new RegExp("^" + REGEX_XRANGE + "$"),
			parseSpermy     : new RegExp("^" + REGEX_EXPR_SPERMY + "$"),
			compTrim        : new RegExp("((<|>)?=|<|>)\\s*(" + REGEX_SEMVER + "|" + REGEX_XRANGE_PLAIN + ")", "g"),
			star            : new RegExp("(<|>)?=?\\s*\\*", "g")
		}

		// parsing methods
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		public static function parse(str:String):Array {
			return str.match(expressions.parse);
		}
		public static function parsePackage(str:String):Array {
			return str.match(expressions.parsePackage);
		}
		public static function parseRange(str:String):Array {
			return str.match(expressions.parseRange);
		}
		public static function validComparator(str:String):Array {
			return str.match(expressions.validComparator);
		}
		public static function parseXRange(str:String):Array {
			return str.match(expressions.parseXRange);
		}
		public static function parseSpermy(str:String):Array {
			return str.match(expressions.parseSpermy);
		}

		// replacement methods
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		public static function replaceStars(stars:String, ...args):String {
			return stars.replace(/^\s+|\s+$/g, "").replace(expressions.star, "");
		}

		// "2.x","2.x.x" --> ">=2.0.0- <2.1.0-"
		// "2.3.x" --> ">=2.3.0- <2.4.0-"
		private static function replaceXRanges(ranges:String, ...args):String {
			return ranges.split(/\s+/).map(replaceXRange).join(" ");
		}

		private static function replaceXRange(version:String, ...args):String {
			return version.replace(/^\s+|\s+$/g, "").replace(expressions.parseXRange, function(v:String, gtlt:String, M:String, m:String, p:String, t:String, ...args):String {
				var anyX:* = !M
					|| M.toLowerCase() === "x" || M === "*"
					|| !m || m.toLowerCase() === "x" || m === "*"
					|| !p || p.toLowerCase() === "x" || p === "*";
				var ret:String = v;

				if (gtlt && anyX) {
					// just replace x'es with zeroes
					if (!M || M === "*" || M.toLowerCase() === "x") M = "0";
					if (!m || m === "*" || m.toLowerCase() === "x") m = "0";
					if (!p || p === "*" || p.toLowerCase() === "x") p = "0";
					ret = gtlt + M + "." + m + "." + p + "-";
				} else if (!M || M === "*" || M.toLowerCase() === "x") {
					ret = "*" // allow any
				} else if (!m || m === "*" || m.toLowerCase() === "x") {
					// append "-" onto the version, otherwise
					// "1.x.x" matches "2.0.0beta", since the tag
					// *lowers* the version value
					ret = ">=" + M + ".0.0- <" + (parseInt(M, 10) + 1) + ".0.0-";
				} else if (!p || p === "*" || p.toLowerCase() === "x") {
					ret = ">=" + M + "." + m + ".0- <" + M + "." + (parseInt(m, 10) + 1) + ".0-";
				}

				return ret;
			});
		}

		/**
		 * ~, ~> --> * (any, kinda silly)
		 * ~2, ~2.x, ~2.x.x, ~>2, ~>2.x ~>2.x.x --> >=2.0.0 <3.0.0
		 * ~2.0, ~2.0.x, ~>2.0, ~>2.0.x --> >=2.0.0 <2.1.0
		 * ~1.2, ~1.2.x, ~>1.2, ~>1.2.x --> >=1.2.0 <1.3.0
		 * ~1.2.3, ~>1.2.3 --> >=1.2.3 <1.3.0
		 * ~1.2.0, ~>1.2.0 --> >=1.2.0 <1.3.0
		 */
		private static function replaceSpermies(version:String, ...args):String {
			return version.replace(/^\s+|\s+$/g, "").replace(expressions.parseSpermy, function(v:String, gtlt:String, M:String, m:String, p:String, t:String, ...args):String {
				if (gtlt) throw new Error("Using '" + gtlt + "' with ~ makes no sense. Don't do it.");

				if (!M || M.toLowerCase() === "x") {
					return "";
				}
				// ~1 == >=1.0.0- <2.0.0-
				if (!m || m.toLowerCase() === "x") {
					return ">=" + M + ".0.0- <" + (parseInt(M, 10) + 1) + ".0.0-";
				}
				// ~1.2 == >=1.2.0- <1.3.0-
				if (!p || p.toLowerCase() === "x") {
					return ">=" + M + "." + m + ".0- <" + M + "." + (parseInt(m, 10) + 1) + ".0-";
				}
				// ~1.2.3 == >=1.2.3- <1.3.0-
				t = t ? t : "-";
				return ">=" + M + "." + m + "." + p + t + " <" + M + "." + (parseInt(m, 10) + 1) + ".0-";
			});
		}

		// string santization methods
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		private static function stringify(version:Array):String {
			var v:Array = version;
			return [v[1]||"", v[2]||"", v[3]||""].join(".") + (v[4]||"") + (v[5]||"");
		}

		public static function clean(version:String):String {
			var version_parsed:Array = parse(version)
			if (!version_parsed) return version;
			return stringify(version_parsed);
		}

		public static function valid(version):String {
			if (typeof version !== "string") return null;
			return parse(version) ? version.replace(/^\s+|\s+$/g, "").replace(/^[v=]+/, "") : null;
		}

		public static function validPackage(version):String {
			if (typeof version !== "string") return null;
			return version.match(expressions.parsePackage) && version.replace(/^\s+|\s+$/g, "");
		}

		public static function validRange(range):String {
			range = replaceStars(range);
			var c:Array = toComparators(range);
			return (c.length === 0) ? null : c.map(function(c, ...args):String { return c.join(" ") }).join("||");
		}

		// comparison methods
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		public static function compare(v1:String, v2:String):int {
			var v1_parsed:Array = parse(v1);
			var v2_parsed:Array = parse(v2);
			if (!v1_parsed || !v2_parsed) return 0;

			for (var i:int = 1; i < 5; i ++) {
				v1_parsed[i] = num(v1_parsed[i]);
				v2_parsed[i] = num(v2_parsed[i]);
				if (v1_parsed[i] > v2_parsed[i]) return 1;
				if (v1_parsed[i] < v2_parsed[i]) return -1;
			}
			// no tag is > than any tag, or use lexicographical order.
			var tag1:String = v1_parsed[5] || "";
			var tag2:String = v2_parsed[5] || "";

			if (tag1 === tag2) return 0;
			if (!tag1) return 1;
			if (!tag2) return -1;
			return tag1 > tag2 ? 1 : -1;
		}

		public static function rcompare(v1:String, v2:String):int {
			return compare(v2, v1);
		}

		public static function satisfies(version:String, range:String):Boolean {
			version = valid(version);
			if (!version) return false;
			var range_comparators:Array = toComparators(range);

			for (var i:int = 0, l:int = range_comparators.length; i < l; i++) {
				var ok:Boolean = false;
				for (var j:int = 0, ll:int = range_comparators[i].length; j < ll; j++) {
					var r:String   = range_comparators[i][j];
					var gtlt:*     = (r.charAt(0) === ">") ? gt : (r.charAt(0) === "<" ? lt : false);
					var eq:Boolean = r.charAt(gtlt ? 1 : 0) === "=";
					var sub:int    = (eq ? 1 : 0) + (gtlt ? 1 : 0);

					if (!gtlt) eq = true;

					r  = r.substr(sub);
					r  = (r === "") ? r : valid(r);
					ok = (r === "") || (eq && r === version) || (gtlt && gtlt(version, r));

					if (!ok) break;
				}
				if (ok) return true;
			}

			return false;
		}

		public static function maxSatisfying(versions:Array, range:String):String {
			return versions
				.filter(function(v, ...args):Boolean { return satisfies(v, range); })
				.sort(compare)
				.pop() || null;
		}

		public static function gt(v1:String, v2:String):Boolean { return compare(v1, v2) === 1; }
		public static function lt(v1:String, v2:String):Boolean { return gt(v2, v1); }
		public static function gte(v1:String, v2:String):Boolean { return !lt(v1, v2); }
		public static function lte(v1:String, v2:String):Boolean { return !gt(v1, v2); }
		public static function eq(v1:String, v2:String):Boolean { return compare(v1, v2) === 0; }
		public static function neq(v1:String, v2:String):Boolean { return compare(v1, v2) !== 0; }
		public static function cmp(v1:String, c:String, v2:String):Boolean {
			switch (c) {
				case ">"   : return gt(v1, v2)
				case "<"   : return lt(v1, v2)
				case ">="  : return gte(v1, v2)
				case "<="  : return lte(v1, v2)
				case "=="  : return eq(v1, v2)
				case "!="  : return neq(v1, v2)
				case "===" : return v1 === v2
				case "!==" : return v1 !== v2
				default    : throw new Error("Y U NO USE VALID COMPARATOR!? " + c);
			}
		}

		// misc utility methods
		// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

		public static function num(v):int {
			return v === undefined ? -1 : parseInt((v||"0").replace(/[^0-9]+/g, ""), 10);
		}

		public static function inc(version:String, release:String):String {
			var version_parsed:Array = parse(version);
			if (!version_parsed) return null;

			var parsedIndexLookup:Object = {'major': 1, 'minor': 2, 'patch': 3, 'build': 4};
			if (!parsedIndexLookup.hasOwnProperty(release)) return null;
			var incIndex:int = parsedIndexLookup[release];

			var current:int = num(version_parsed[incIndex])
			version_parsed[incIndex] = current === -1 ? 1 : current + 1

			for (var i:int = incIndex + 1; i < 5; i++) {
				if (num(version_parsed[i]) !== -1) version_parsed[i] = "0";
			}

			if (version_parsed[4]) version_parsed[4] = "-" + version_parsed[4];
			version_parsed[5] = "";

			return stringify(version_parsed);
		}

		public static function toComparators(range:String):Array {
			return (range || "")
				.replace(/^\s+|\s+$/g, "")
				.replace(expressions.parseRange, RANGE_REPLACE)
				.replace(expressions.compTrim, "$1$3")
				.split(/\s+/)
				.join(" ")
				.split("||")
				.map(function(orchunk:String, ...args):String {
					return orchunk
						.replace(new RegExp("(" + REGEX_EXPR_LONE_SPERMY + ")\\s+"), "$1")
						.split(" ")
						.map(replaceXRanges)
						.map(replaceSpermies)
						.map(replaceStars)
						.join(" ")
						.replace(/^\s+|\s+$/g, "");
				})
				.map(function(orchunk:String, ...args):Array {
					return orchunk
						.replace(/^\s+|\s+$/g, "")
						.split(/\s+/)
						.filter(function(c:String, ...args):Boolean { return c.match(expressions.validComparator); })
				})
				.filter(function(cc:Array, ...args):Boolean { return cc && cc.length > 0; });
		}

	}
}