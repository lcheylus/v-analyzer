module main

import term
import testing

fn main() {
	mut testers := []testing.Tester{}

	testers << definitions()
	testers << implementations()
	testers << supers()
	testers << completion()
	testers << types()

	for mut tester in testers {
		println('Running ${term.bg_blue(' ' + tester.name + ' ')}')
		tester.run()
		println('')
		tester.stats().print()
		println('')
	}

	mut all_stats := testing.TesterStats{}

	for tester in testers {
		all_stats = all_stats.merge(tester.stats())
	}

	println(term.bg_blue(' All tests: '))
	all_stats.print()

	if all_stats.failed > 0 {
		println('')
		println(term.bg_red(' Failed tests: '))
		for mut tester in testers {
			for failed_test in tester.failed_tests() {
				failed_test.print()
			}
		}
	}
}
