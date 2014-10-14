TableAdapter
============

A replacement for `UITableViewDataSource` and `UITableViewDelegate`

###Background
Implementing `UITableViewDataSource` and `UITableViewDelegate` methods in each view controller is a pain. Not to mention when using different cells in the table view. This framework aims to solve the issue by providing an object to represent a table view section and a controller to manage multiple sections.

###Example:
To set up your table view, you must:
1. Initialize an instance of `TableViewDataSource` (Either in a storyboard or code).
2. Set the `TableViewDataSource`'s `tableView` property (Either in storyboard or code).
3. Manually register the cell classes to the `tableView` using `registerClass:forCellReuseIdentifier:` or `registerNib:forCellReuseIdentifier:`
4. In `viewDidLoad`, configure a `TableViewSection`, and configure the properties as you wish.
  - Only the properties that are not explicitly marked as optional (`?`) are required.
5. Add the section to the data source

````
class ExampleViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var dataSource = TableViewDataSource()
    
    // Other properties...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // !!!: If not using storyboards or .xib's, cell classes must be manually registered with table view
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TestCell")
        tableView.registerNib(TableSectionHeaderView.nib(), forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        // !!!: You must set the TableViewDataSource tableView
        tableDataSource.tableView = tableView
        
        // !!!: Configure the section
        var sectionOne = TableViewSection()
        sectionOne.objects = dataSource
        sectionOne.rowHeight = 50
        sectionOne.sectionHeaderHeight = 75
        sectionOne.sectionFooterHeight = 15
        sectionOne.cellIdentifierBlock = { _, _ in return "TestCell" }
        sectionOne.headerConfigurationBlock = headerConfiguration
        sectionOne.cellConfigurationBlock = cellConfiguration
        sectionOne.footerConfigurationBlock = footerConfiguration
        sectionOne.selectionBlock = cellSelectionBlock
        
        tableDataSource.addSection(sectionOne)
    }
    
    // Other methods...
}
````

###Question? Need help?
File an issue and we'll be happy to help.

###TODO:
 - [ ] Show/hide sections
 - [ ] Documentation
 - [ ] Tests
 - [ ] Exceptions for `DEBUG` builds
