class PageEditor extends React.Component {

  static propTypes = {
    rawContent: React.PropTypes.string.isRequired
  };

  constructor(props) {
    super(props);

    this.state = {
      rawContent: this.props.rawContent
    }
  }

  savePage() {
    var url = window.location.pathname.replace(/edit$/, '');
    $.ajax({
      url: url,
      type: 'PUT',
      data: {
        content: this.state.rawContent,
        newTitle: this.props.full_title
      }
    }).done(function(data) {
      window.location.pathname = '/wiki/' + data.newTitle;
    });
  }

  onCancel() {
    history.back();
  }

  render() {
    var metadata = this.state.rawContent.substring(this.state.rawContent.indexOf('== Metadata =='));
    var lines = metadata.split('\n');
    lines = lines.filter(function(line) {
      return line[0] == '*' && line.match(/\[\[[\S ]+\]\]/);
    }).map(function(line) {
      line = line.substring(1).trim();
      return line.substring(line.indexOf('[['));
    });

    var triples = lines.map(function(line, index) {
      line = line.replace('[[', '').replace(']]', '');
      return {
        predicate: line.split('::')[0],
        object: line.split('::')[1],
        id: index
      }
    });

    return <div>
      <div id="contentTop">
        <div id="topEditBar" className="editBar">
          <div className="btn-toolbar editing" style={{display: 'block'}}>
            <div className="btn-group">
              <div className="editButton btn btn-small" id="pageCancelButton" onClick={this.onCancel.bind(this)}>
                <i className="icon-remove" />
                <strong>Cancel</strong>
              </div>
              <div className="editButton btn btn-small" id="pageSaveButton" onClick={this.savePage.bind(this)}>
                <i className="icon-ok" />
                <strong>Save</strong>
              </div>
            </div>
          </div>
        </div>
        <div id="title">
          <h1>{this.props.full_title}</h1>
        </div>
      </div>
      <div id="sections">
        <div id="sections-source" style={{height: '1200px', width: '100%' }}>
          <Editor theme='wiki'
            mode='wiki'
            value={this.state.rawContent}
            onChange={this.onChangeContent.bind(this)}
            height='300px'
            width='820px' />
          <MetaDataEditor
            triples={triples}
            pages={this.props.pages}
            onChange={this.onChangeTriples.bind(this)}
            predicates={this.props.predicates}  />
        </div>;
      </div>
    </div>
  }

  onChangeTriples(triples) {
    var pageWithoutMetadata = this.state.rawContent.substring(0, this.state.rawContent.indexOf('== Metadata =='));

    var metadata = '== Metadata ==\n\n' + triples.map(function(triple) {
      return '* [[' + triple.predicate + '::' + triple.object + ']]';
    }).join('\n') + '\n\n';

    this.setState({ rawContent: pageWithoutMetadata + metadata });
  }

  onChangeContent(content) {
    this.setState({ rawContent: content });
  }

}
