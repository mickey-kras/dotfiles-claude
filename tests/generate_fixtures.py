from helpers import write_fixture, render_template
from test_render_snapshots import PROFILE_CASES, SNAPSHOTS


def main():
    for case_name, override_data in PROFILE_CASES.items():
        for template_path, fixture_name in SNAPSHOTS.items():
            write_fixture(
                f"tests/fixtures/rendered/software-development/{case_name}/{fixture_name}",
                render_template(template_path, override_data),
            )


if __name__ == "__main__":
    main()
