"""Sample lambda handler."""

from example.util.logger import LogEvents, get_logger

log = get_logger()


def do_stuff(_, __):
    """This handler serves to illustrate how the code would look.

    Args:
        _ (Event): Unused, only present to match the Lambda handler signature.
        __ (Context): Unused, only present to match the Lambda handler signature.
    """

    log.info(event=LogEvents.EXAMPLE)
    log.info(event=LogEvents.EXAMPLE_SUCCESSFUL)
    return "Hello, World!"


if __name__ == "__main__":
    do_stuff(None, None)
