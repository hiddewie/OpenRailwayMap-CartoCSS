
class AbstractAPI:
    '''Methods used by multiple parts of the OpenRailwayMap API'''

    MAX_LIMIT = 200

    def build_result_item_dict(self, description, row):
        item = {}
        for i in range(len(row)):
            # TODO handle general tags
            if description[i].name == 'tags' and row[i]:
                for k, v in row[i].items():
                    item[k] = v
            else:
                item[description[i].name] = row[i]
        return item
