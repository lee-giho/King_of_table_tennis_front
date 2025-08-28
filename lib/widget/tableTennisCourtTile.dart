import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/table_tennis_court_dto.dart';

class TableTennisCourtTile extends StatefulWidget {
  final TableTennisCourtDTO tableTennisCourtDTO;
  const TableTennisCourtTile({
    super.key,
    required this.tableTennisCourtDTO
  });

  @override
  State<TableTennisCourtTile> createState() => _TableTennisCourtTileState();
}

class _TableTennisCourtTileState extends State<TableTennisCourtTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black
        ),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.tableTennisCourtDTO.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on
              ),
              Expanded(
                child: Text(
                  widget.tableTennisCourtDTO.address,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(
                Icons.call
              ),
              Expanded(
                child: Text(
                  widget.tableTennisCourtDTO.phoneNumber,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}