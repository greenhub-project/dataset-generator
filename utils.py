import re

def load_dotenv(filepath = '.env'):
    envre = re.compile(r'''^([^\s=]+)=(?:[\s"']*)(.+?)(?:[\s"']*)$''')
    result = {}
    with open(filepath) as ins:
        for line in ins:
            match = envre.match(line)
            if match is not None:
                result[match.group(1)] = match.group(2)
    return result


def get_conn():
    env = load_dotenv()
    conn = 'mysql+mysqlconnector://' + env['DB_USERNAME']
    conn += ':' + env['DB_PASSWORD']
    conn += '@' + env['DB_HOST']
    conn += ':' + env['DB_PORT']
    conn += '/' + env['DB_DATABASE']
    return conn